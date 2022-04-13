using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(TrailRenderer))]
public class PlayerController : MonoBehaviour
{
    [SerializeField] private float speed = 200.0f;
    [SerializeField] private float boostFactor = 4.0f;
    [SerializeField] private float power = 2.0f;
    [SerializeField] private TerrainGenerator generatedTerrain;

    private float trailDecay = 5.0f;
    private float modifiedSpeed;
    private Vector3 movementDirection; 
    private TrailRenderer trail;

    void Awake()
    {
        this.transform.position = new Vector3(this.generatedTerrain.width/2, this.generatedTerrain.height/2, this.transform.position.z);
        this.trail = this.GetComponent<TrailRenderer>();

        if(this.generatedTerrain == null)
        {
            Debug.Log("You need pass a TrarrainGenerator component to the player.");
            throw new MissingComponentException();
        }
    }

    public float GetCurrentSpeed()
    {
        return this.modifiedSpeed;
    }

    public Vector3 GetMovementDirection()
    {
        return this.movementDirection;
    }

    void Update()
    {
        bool fire1Down = Input.GetButtonDown("Fire1");
        bool fire1Pressed = Input.GetButton("Fire1");
        bool fire1Up = Input.GetButtonUp("Fire1");

        bool fire2Down = Input.GetButtonDown("Fire2");
        bool fire2Pressed = Input.GetButton("Fire2");
        bool fire2Up = Input.GetButtonUp("Fire2");

        if(fire1Pressed)
        {
            this.generatedTerrain.ChangeTerrainHeight(this.gameObject.transform.position, this.power);
        }

        if(fire2Pressed)
        {
            this.generatedTerrain.ChangeTerrainHeight(this.gameObject.transform.position, -this.power);
        }

        if( (fire1Down && !fire2Pressed) || (fire2Down && !fire1Pressed)) 
        {
            Debug.Log("beam!!!");
            FindObjectOfType<SoundManager>().PlaySoundEffect("Beam");
        }

        if( (fire1Up && !fire2Pressed) || (fire2Up && !fire1Pressed))
        {
            FindObjectOfType<SoundManager>().StopSoundEffect("Beam");
        }

        this.modifiedSpeed = this.speed;

        if (Input.GetButton("Jump")) 
        {
            this.modifiedSpeed *= this.boostFactor;
            this.trail.widthMultiplier = this.boostFactor;

            if(Input.GetButtonDown("Jump"))
            {
                FindObjectOfType<SoundManager>().PlaySoundEffect("SonicBoom");
            }
        }
        else
        {
            if(this.trail.widthMultiplier >= 1.0f) {
                this.trail.widthMultiplier -= Time.deltaTime * this.trailDecay;
            }
        }
        
        this.movementDirection = new Vector3(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"), 0.0f);
        this.gameObject.transform.Translate(this.movementDirection * Time.deltaTime * this.modifiedSpeed);
    }
}
